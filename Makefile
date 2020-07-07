#default: latest intel nvidia

# =====
# TOOLS
# =====

tools-nvidia:
	docker build --rm \
	--build-arg from=eleramp/devenv:nvidia-10.0-devel \
	--tag eleramp/tools:nvidia-10.0-devel \
	Tools/

# ===========
# DEVELOPMENT
# ===========

#development-latest: development-master
#	docker tag eleramp/development:master eleramp/development:latest

#development-master:
#	docker build --rm \
#		--build-arg from=eleramp/tools \
#		--tag eleramp/development:master \
#		--build-arg SOURCES_GIT_BRANCH=master \
#		Development/

development-nvidia:
	docker build --rm \
		--build-arg from=eleramp/tools:nvidia \
		--tag eleramp/development:nvidia \
		--build-arg SOURCES_GIT_BRANCH=master \
		Development/

# ======================
# REINFORCEMENT LEARNING
# ======================

#rl-latest: rl-master
#	docker tag eleramp/rl:master eleramp/rl:latest

#rl-master:
#	docker build --rm \
#		--build-arg from=eleramp/development:master \
#		--tag eleramp/rl:master \
#		RL/

#rl-ubuntu:
#	docker build --rm \
#		--build-arg from=ubuntu:bionic \
#		--tag eleramp/rl:ubuntu \
#		RL/

rl-nvidia:
	docker build --rm \
		--build-arg from=eleramp/development:nvidia \
		--tag eleramp/rl:nvidia \
		RL/

gpnet:
	docker build --rm \
		--build-arg from=eleramp/tools:nvidia-10.0-devel \
		--tag eleramp/graspnet:nvidia-10.0-devel \
		graspnet/

# ======
# DEPLOY
# ======

# push-tools: tools
# 	docker push eleramp/tools

# push-development-latest: development-latest
# 	docker push eleramp/development:latest

# push-development-master: development-master
# 	docker push eleramp/development:master

# push-rl-latest: rl-latest
# 	docker push eleramp/rl:latest

# push-rl-master: rl-master
# 	docker push eleramp/rl:master

# push-rl-ubuntu: rl-ubuntu
# 	docker push eleramp/rl:ubuntu
