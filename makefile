.PHONY: run

run:
	@bin/rails db:prepare db:seed
	@bin/dev