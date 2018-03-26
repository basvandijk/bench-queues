module MisoQueue
    ( MisoQueue
    , newMisoQueue
    , writeMisoQueue
    , flushMisoQueue
    ) where

import Data.IORef
import Data.Sequence (Seq, (|>))
import qualified Data.Sequence as Sequence
import Data.Foldable
import Data.Functor
import Control.Concurrent.MVar

data MisoQueue a = MisoQueue (IORef (Seq a))
                             (MVar ())

newMisoQueue :: IO (MisoQueue a)
newMisoQueue = MisoQueue <$> newIORef Sequence.empty
                         <*> newMVar ()

writeMisoQueue :: MisoQueue a -> a -> IO ()
writeMisoQueue (MisoQueue seqIORef notifyMVar) x = do
    atomicModifyIORef' seqIORef $ \xs -> (xs |> x, ())
    void $ tryPutMVar notifyMVar ()

flushMisoQueue :: MisoQueue a -> IO [a]
flushMisoQueue (MisoQueue seqIORef notifyMVar) = do
    takeMVar notifyMVar
    xs <- atomicModifyIORef' seqIORef $ \xs -> (Sequence.empty, xs)
    pure $ toList xs
