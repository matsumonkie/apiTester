{-# LANGUAGE DeriveAnyClass         #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE QuasiQuotes            #-}
{-# LANGUAGE TemplateHaskell        #-}

module Environment.DB where

import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.SqlQQ
import           GHC.Generics

-- * fake environment


data FakeEnvironment =
  FakeEnvironment { _fakeEnvironmentId   :: Int
                  , _fakeEnvironmentName :: String
                  }
  deriving (Eq, Show, Read, Generic, FromRow)

selectFakeEnvironment :: Int -> Connection -> IO FakeEnvironment
selectFakeEnvironment environmentId connection = do
  [fakeEnvironment] <- query connection rawQuery (Only environmentId)
  return fakeEnvironment
  where
    rawQuery =
      [sql|
          SELECT id, name
          FROM environment
          WHERE id = ?
          |]


-- * fake account environment


data FakeAccountEnvironment =
  FakeAccountEnvironment { _fakeAccountEnvironmentAccountId     :: Int
                         , _fakeAccountEnvironmentEnvironmentId :: Int
                         }
  deriving (Eq, Show, Read, Generic, FromRow)

selectFakeAccountEnvironments :: Int -> Connection -> IO [FakeAccountEnvironment]
selectFakeAccountEnvironments accountId connection = do
  fakeAccountEnvironments <- query connection rawQuery (Only accountId)
  return fakeAccountEnvironments
  where
    rawQuery =
      [sql|
          SELECT account_id, environment_id
          FROM account_environment
          WHERE account_id = ?
          |]
