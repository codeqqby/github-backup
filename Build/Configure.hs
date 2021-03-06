{- Checks system configuration and generates SysConfig.hs. -}

{-# OPTIONS_GHC -fno-warn-tabs #-}

module Build.Configure where

import System.Environment
import Control.Applicative
import Control.Monad.IfElse

import Build.TestConfig
import Build.Version
import Git.Version

tests :: [TestCase]
tests =
	[ TestCase "version" (Config "version" . StringConfig <$> getVersion)
	, TestCase "git" $ requireCmd "git" "git --version >/dev/null"
	, TestCase "git version" getGitVersion
	]

getGitVersion :: Test
getGitVersion = Config "gitversion" . StringConfig . show
	<$> Git.Version.installed

run :: [TestCase] -> IO ()
run ts = do
	args <- getArgs
	config <- runTests ts
	writeSysConfig config
	whenM (isReleaseBuild) $
		cabalSetup "github-backup.cabal"
