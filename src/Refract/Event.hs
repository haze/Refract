module Refract.Event
    ( Event
    , Filter
    ) where

class Filter a where
    pass :: a -> Bool
    pass _ = True

class (Filter a) => Event a where
    filters :: [a]
    filters = [ ]
