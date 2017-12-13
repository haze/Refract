module Main where

import qualified Control.Concurrent.MVar as M
import qualified Refract.Bus as R
import           Refract.Event

smallerThanSix :: MessageEvent -> Bool
smallerThanSix (MessageEvent msg) = length msg < 6

newtype MessageEvent = MessageEvent String
instance Event MessageEvent where
    base = MessageEvent ""

showMessage :: MessageEvent -> IO ()
showMessage (MessageEvent msg) = putStrLn msg

showMessage' :: MessageEvent -> IO ()
showMessage' (MessageEvent msg) = putStrLn $ "should be second: " ++ msg

main :: IO ()
main = do
    bus <- R.createBlankBus (base :: MessageEvent)
    R.associate' showMessage' bus
    R.associate 0 showMessage bus
    R.fire (MessageEvent "hello") bus