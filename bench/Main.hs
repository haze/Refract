module Main where

import qualified Control.Concurrent.MVar as M
import           Criterion.Main
import           Criterion.Types
import qualified Refract.Bus             as R
import           Refract.Event
import           System.Exit             (exitSuccess)


match :: String -> CommandEvent -> Bool
match b (CommandEvent (x, _)) = b == x

multimatch :: [String] -> [CommandEvent -> Bool]
multimatch = map match

newtype CommandEvent = CommandEvent (String, String)
instance Event CommandEvent where
  base = CommandEvent ("", "")
  filters _ = multimatch ["A", "B", "C"]

matchCommandA :: CommandEvent -> IO ()
matchCommandA (CommandEvent (_, b)) = print $ "I'm Command A: " ++ b

matchCommandB :: CommandEvent -> IO ()
matchCommandB (CommandEvent (_, b)) = print $ "I'm Command B: " ++ b

matchCommandC :: CommandEvent -> IO ()
matchCommandC (CommandEvent (_, b)) = print $ "I'm Command C: " ++ b

conf :: Config
conf = defaultConfig {
          resamples = 10,
          timeLimit = 10,
          verbosity = Verbose
       }

main :: IO ()
main = do
    bus <- R.createBlankBus (base :: CommandEvent)
    sequence_ $ R.batchAssociate' [matchCommandA, matchCommandB, matchCommandC] bus
    defaultMainWith conf [
      bgroup "fire" [ bench "A" $ whnfIO $ R.fire bus (CommandEvent ("A", "I'm A!"))
                    , bench "B" $ whnfIO $ R.fire bus (CommandEvent ("B", "I'm B!"))
                    , bench "C" $ whnfIO $ R.fire bus (CommandEvent ("C", "I'm C!"))
                    ]
                ]
