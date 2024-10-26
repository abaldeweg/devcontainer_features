#!/bin/sh

set -e

CUSTOM_BASH_FILE="/usr/local/etc/bash_custom.sh"

cat << 'EOF' > "$CUSTOM_BASH_FILE"
#!/bin/bash

git config --global pull.rebase false

if command -v yarn &> /dev/null; then
  PATH="$(yarn global bin):$PATH"
fi

alias ll='ls -alF'

alias push='git push origin --follow-tags'
alias ws="yarn workspace"

function tag()
{
  if [[ $(git status -s) ]];
    then
      echo "Git repo has uncommitted changes."
      git status -s
    else
      #!/bin/sh

      echo "Latest tags"
      git describe --tags --abbrev=0 $(git rev-list --tags --max-count=3)

      read -p "Please set the version number in your files. Press any key to continue..." _

      read -p "Version: " tag

      if [ -z "$tag" ]; then
        echo "Error: Version tag cannot be empty."
        exit 1
      fi

      read -p "Subpackage (optional): " subpackage

      if [ -n "$subpackage" ]; then
        subpackage="${subpackage}/"
      fi

      echo "Set tag ${subpackage}${tag}"

      git tag -a "v${tag}" -m "v${tag}"
  fi
}

function dev()
{
  if [ -f yarn.lock ]
    then
      yarn dev
  fi
  if [ -f composer.json ]
    then
      symfony server:start --no-tls
  fi
  if [ -f package-lock.json ]
    then
      npm run dev
  fi
  if [ -f docker-compose.yml ]
    then
      sudo docker-compose up
  fi
  if [ -f go.sum ]
    then
      go run ./
  fi
  if [ -f hugo.yaml ]
    then
      hugo server
  fi
}

function build()
{
  if [ -f yarn.lock ]
    then
      yarn build
  fi
  if [ -f composer.json ]
    then
      vendor/bin/php-cs-fixer fix
      bin/phpunit
  fi
  if [ -f package-lock.json ]
    then
      npm run build
  fi
  if [ -f .goreleaser.yaml ]
    then
      goreleaser build --snapshot --rm-dist
  fi
    if [ -f Makefile ]
    then
      make build
  fi
  if [ -f hugo.yaml ]
    then
      hugo --minify
  fi
}
EOF

echo "source $CUSTOM_BASH_FILE" >> /etc/bash.bashrc
