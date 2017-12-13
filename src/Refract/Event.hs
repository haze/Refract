module Refract.Event
    ( highPriority
    , normalPriority
    , lowPriority
    , Priority
    , Event
    , Filter
    ) where

-- Priority stuff
type Priority = Int

highPriority :: Priority
highPriority = 0

normalPriority :: Priority
normalPriority = 1

lowPriority :: Priority
lowPriority = 2

class Filter a where
    pass :: a -> Bool
    pass _ = True

class (Filter a) => Event a where
    filters :: [a]
    filters = [ ]
    priority :: a -> Priority
    priority _ = normalPriority
    base :: a
