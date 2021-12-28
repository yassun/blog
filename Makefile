deploy:
	zola build
	echo 'blog.yasun.dev' > public/CNAME
	npm run deploy
