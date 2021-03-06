setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../../scripts/h2o-r-test-setup.R")



test.gbm.regr.accessors <- function() {
  cars.hex <- h2o.uploadFile(locate("smalldata/junit/cars.csv"))
  c.sid <- h2o.runif(cars.hex)
  cars.train <- h2o.assign(cars.hex[c.sid > .2, ], "cars.train")
  cars.test <- h2o.assign(cars.hex[c.sid <= .2, ], "cars.test")
  cars.gbm <- h2o.gbm(x = 3:7, y = 2, training_frame = cars.train)
  cars.gbm.valid <- h2o.gbm(x = 3:7, y = 2, training_frame = cars.train, validation_frame = cars.test)
  cars.gbm.valid.xval <- h2o.gbm(x = 3:7, y = 2, training_frame = cars.train, validation_frame = cars.test, nfolds=2)

  Log.info("MSE...")
  mse.basic <- h2o.mse(cars.gbm)
  print(mse.basic)
  expect_warning(h2o.mse(cars.gbm, valid = TRUE))
  mse.valid.F <- h2o.mse(cars.gbm.valid)
  mse.valid.T <- h2o.mse(cars.gbm.valid,valid = TRUE)
  print(mse.valid.T)
  expect_equal(mse.basic, mse.valid.F) # basic should equal valid with valid = FALSE
  mse.valid.xval.T <- h2o.mse(cars.gbm.valid.xval,train=TRUE,valid=TRUE,xval=TRUE)
  expect_true(length(mse.valid.xval.T)==3)
  expect_true(mse.valid.xval.T["train"]==mse.basic)
  expect_true(mse.valid.xval.T["valid"]==mse.valid.T)

  Log.info("Mean Residual Deviance...")
  mean_residual_deviance.basic <- h2o.mean_residual_deviance(cars.gbm)
  print(mean_residual_deviance.basic)
  expect_warning(h2o.mean_residual_deviance(cars.gbm, valid = TRUE))
  mean_residual_deviance.valid.F <- h2o.mean_residual_deviance(cars.gbm.valid)
  mean_residual_deviance.valid.T <- h2o.mean_residual_deviance(cars.gbm.valid,valid = TRUE)
  print(mean_residual_deviance.valid.T)
  expect_equal(mean_residual_deviance.basic, mean_residual_deviance.valid.F) # basic should equal valid with valid = FALSE
  mean_residual_deviance.valid.xval.T <- h2o.mean_residual_deviance(cars.gbm.valid.xval,train=TRUE,valid=TRUE,xval=TRUE)
  expect_true(length(mean_residual_deviance.valid.xval.T)==3)
  expect_true(mean_residual_deviance.valid.xval.T["train"]==mean_residual_deviance.basic)
  expect_true(mean_residual_deviance.valid.xval.T["valid"]==mean_residual_deviance.valid.T)

  Log.info("Variable Importance...")
  print(h2o.varimp(cars.gbm))

  
}

doTest("Testing model accessors for GBM", test.gbm.regr.accessors)
