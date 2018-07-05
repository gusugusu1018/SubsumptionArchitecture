all:
	../../processing-java --sketch=$(shell pwd)/SAProcessing --output=$(shell pwd)/SAProcessing/output_dir --force --run
v1:
	../../processing-java --sketch=$(shell pwd)/SAProcessingv1 --output=$(shell pwd)/SAProcessingv1/output_dir --force --run
line:
	../../processing-java --sketch=$(shell pwd)/SAProcessingLine --output=$(shell pwd)/SAProcessingLine/output_dir --force --run
