module Refract.Event
    ( Event
    , base
    , filters
    ) where


class Event a where
    filters   :: a -> [a -> Bool]
    filters _ = [ ]
    base :: a