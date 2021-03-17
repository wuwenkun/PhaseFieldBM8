#include "NucleationBMAPP.h"
#include "MooseInit.h"
#include "Moose.h"
#include "MooseApp.h"
#include "AppFactory.h"

// Create a performance log
PerfLog Moose::perf_log("NucleationBM");

// Begin the main program.
int main(int argc, char *argv[])
{
  // Initialize MPI, solvers and MOOSE
  MooseInit init(argc, argv);

  // Register this application's MooseApp and any it depends on
  NucleationBMAPP::registerApps();

  // Create an instance of the application and store it in a smart pointer for easy cleanup
  std::shared_ptr<MooseApp> app = AppFactory::createAppShared("NucleationBMAPP", argc, argv);

  // Execute the application
  app->run();

  // Free up the memory we created earlier
  //delete app;

  return 0;
}
