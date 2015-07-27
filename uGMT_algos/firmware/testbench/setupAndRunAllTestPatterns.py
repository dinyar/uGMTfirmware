import os
import subprocess

testpatterns = [many_events, fwd_iso_scan, iso_test, ttbar_small_sample]

error = 0

for pattern in testpatterns:
  print "#################################################################################"
  print "Running " + pattern + " pattern:"
  error += subprocess.call(os.getcwd() + "/setupAndRunAll.sh " + pattern, shell=True)
  print "#################################################################################"

return error
