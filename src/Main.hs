{-# language CPP #-}
{-# language RankNTypes #-}
{-# language BangPatterns #-}
{-# language NumDecimals #-}

module Main where

#ifdef __GHCJS__
import CriterionStub
#else
import Criterion.Main
#endif

import Control.Concurrent (forkIO)
import Control.Concurrent.STM.TQueue
import Control.Monad.STM (atomically)
import Control.Monad (replicateM_)
import Text.Printf (printf)
import MisoQueue

--------------------------------------------------------------------------------

main :: IO ()
main = defaultMain
    [ let n = 1e6; w = 10 in bcompare (printf "A n=%i w=%i" n w) $ benchQueueA n w
    , let n = 1e6; w = 10 in bcompare (printf "B n=%i w=%i" n w) $ benchQueueB n w
    ]

bcompare :: String -> (forall q. Queue q -> IO a) -> Benchmark
bcompare name f =
    bgroup name
    [ bench "TQueue"    $ whnfIO $ f tQueue
    , bench "MisoQueue" $ whnfIO $ f misoQueue
    ]

--------------------------------------------------------------------------------

benchQueueA
    :: Int -- ^ number of elements to write
    -> Int -- ^ number of writer threads
    -> Queue q
    -> IO ()
benchQueueA n w queue = do
    q <- newQueue queue

    writeQueue queue q ()

    let loop :: Int -> IO ()
        loop !m | m == n = pure ()
                | otherwise = do
                    xs <- flushQueue queue q
                    let !s = m + length xs
                        !r = n - s
                        !w' = min r w
                    replicateM_ w' $
                      forkIO $ do
                        writeQueue queue q ()
                    loop s

    loop 1

benchQueueB
    :: Int -- ^ number of elements to write
    -> Int -- ^ number of writer threads
    -> Queue q
    -> IO ()
benchQueueB n w queue = do
    q <- newQueue queue
    replicateM_ w $
      forkIO $
        replicateM_ (n `quot` w) $
          writeQueue queue q ()

    let loop :: Int -> IO ()
        loop !m | m == n = pure ()
                | otherwise = do
                    xs <- flushQueue queue q
                    loop (m + length xs)
    loop 0

--------------------------------------------------------------------------------

data Queue q = Queue
    { newQueue   :: forall a. IO (q a)
    , writeQueue :: forall a. q a -> a -> IO ()
    , flushQueue :: forall a. q a -> IO [a]
    }

tQueue :: Queue TQueue
tQueue =
    Queue
    { newQueue   = newTQueueIO
    , writeQueue = \q x -> atomically $ writeTQueue q x
    , flushQueue = \q   -> atomically $ flushTQueue q
    }

misoQueue :: Queue MisoQueue
misoQueue =
    Queue
    { newQueue   = newMisoQueue
    , writeQueue = writeMisoQueue
    , flushQueue = flushMisoQueue
    }
