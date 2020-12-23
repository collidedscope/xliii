xliii: xliii.cr
	$(MAKE) -C ckociemba lib
	crystal build --release --no-debug xliii.cr

dev: xliii.cr
	$(MAKE) -C ckociemba lib
	crystal build xliii.cr
