{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}


module RequestCollection.Model where


import           Data.Aeson
import qualified Database.PostgreSQL.Simple.FromRow as PG
import           GHC.Generics
import           RequestNode.Model


-- * Model


data RequestCollection =
  RequestCollection Int [RequestNode]
  deriving (Eq, Show, Generic, ToJSON, FromJSON, PG.FromRow)
