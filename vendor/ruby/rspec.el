;; Simple skeletons for rspec/mspec tests

(define-skeleton rspec-test-skeleton
  "Inserts an 'it' block"
  ""
  "it \"" _ "\" do"
  "\n">"\nend")

(define-skeleton rspec-describe-skeleton
  "Inserts an 'describe' block"
  ""
  "describe \"" _ "\" do" \n
  >
  "\nend")

(define-skeleton rspec-before-each-skeleton
  "Inserts a 'before :each' block"
  ""
  "before :each do" \n
  _ 
  "\nend")







