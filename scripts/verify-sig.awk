/file:/ { file=$2 }
/tailed:/ { tailed=1 }
/message:/ { message=$2 }
/address:/ { address=$2 }
/signature:/ { signature=$2 }
END {
  printf("Verifying %s...\n", message);
  printf("Should equal: ");
  if(tailed == "1") {
    system(sprintf("tail -c 64 \"%s\" | cut -d ' ' -f 1", file));
  } else {
    system(sprintf("sha256sum \"%s\" | cut -d ' ' -f 1", file));
  }
  exit(system(sprintf("if [[ 'True' == \"$(trezorctl btc verify-message '%s' '%s' '%s')\" ]]; then echo true; exit 0; else echo false; exit 1; fi", address, signature, message)))
}
