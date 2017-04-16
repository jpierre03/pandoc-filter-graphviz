all: test.pdf pandoc-filter-graphviz

build:
	stack build

install:

pandoc-filter-graphviz: build install

test.pdf: test.md
	pandoc -s test.md --filter pandoc-filter-graphviz -o test.pdf
