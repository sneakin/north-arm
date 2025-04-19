( Output dictionary listings: )

def oword-printer
  arg0 dict-entry-name peek from-out-addr write-string space
  arg1 1 + set-arg0
end

def ciwords
  cross-immediates peek dup IF cs + ' words-printer dict-map THEN
end

def owords
  out-dict out-origin peek 0 pointer oword-printer dict-map/4
end

def oiwords
  output-immediates @ out-origin peek 0 pointer oword-printer dict-map/4
end
