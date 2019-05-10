SRC=.

echo $(for i in `find $SRC -name "*.wtest"`; do ./winterpreter.sh $i; done) 
