{-# language LambdaCase #-}
{-# language GADTs #-}

module CriterionStub
    ( Benchmarkable
    , Benchmark
    , defaultMain
    , bgroup
    , bench
    , whnfIO
    ) where

import Data.Time.Clock (getCurrentTime, diffUTCTime)
import Control.Exception (evaluate)
import Data.Functor (void)
import Data.Foldable (traverse_)

type Benchmarkable = IO ()

data Benchmark where
    Benchmark  :: String -> Benchmarkable -> Benchmark
    BenchGroup :: String -> [Benchmark] -> Benchmark

defaultMain :: [Benchmark] -> IO ()
defaultMain = go ""
  where
    go :: String -> [Benchmark] -> IO ()
    go indentation = traverse_ $ \case
      Benchmark name benchmarkable -> do
        putStr (indentation ++ name ++ "... ")
        tBegin <- getCurrentTime
        benchmarkable
        tEnd <- getCurrentTime
        print (diffUTCTime tEnd tBegin)
      BenchGroup name bs -> do
        putStrLn (indentation ++ name)
        go ("  " ++ indentation) bs

bgroup :: String -> [Benchmark] -> Benchmark
bgroup = BenchGroup

bench :: String -> Benchmarkable -> Benchmark
bench = Benchmark

whnfIO :: IO a -> Benchmarkable
whnfIO a = void $ a >>= evaluate
