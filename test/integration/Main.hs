import Data.Pool (Pool)
import Database.Persist.Migration (MigrateBackend)
import qualified Database.Persist.Migration.Postgres as Postgres
import Database.Persist.Sql (SqlBackend)
import System.IO.Temp (withTempDirectory)
import Test.Tasty

import Migration (testMigrations)
import Property (testProperties)
import Utils.Backends (withPostgres)
import Utils.Goldens (goldenDir)

integrationDir :: String -> FilePath
integrationDir = goldenDir "integration"

main :: IO ()
main = withTempDirectory "/tmp" "persistent-migration-integration" $ \dir ->
  defaultMain $ testGroup "persistent-migration-integration"
    [ withPostgres dir $ testBackend "postgresql" Postgres.backend
    ]

-- | Build a test suite running integration tests for the given MigrateBackend.
testBackend :: String -> MigrateBackend -> IO (Pool SqlBackend) -> TestTree
testBackend label backend getPool = testGroup label
  [ testMigrations (integrationDir label) backend getPool
  , testProperties backend getPool
  ]
