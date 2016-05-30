# --- prerequisite from first run ---
@test 'package is installed' {
  rpm -q nmap-ncat
}

@test 'previous puppet run log file 1/2' {
  ls /tmp/exec.txt
}

@test 'previous puppet run log file 2/2' {
  ls /tmp/demo.txt
}


# --- second run ---
@test 'second puppet run attempted/completed' {
  ls /tmp/second_run_completed.txt 
}

@test 'execs dont run if package installed already 1/2' {
  # file must not exist
  run test ! -f /tmp/exec_second_run.txt
}

@test 'execs dont run if package installed already 2/2' {
  # file must not exist
  run test ! -f /tmp/demo_second_run.txt
} 
