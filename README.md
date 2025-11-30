# Weewx in docker image (unofficial)

This is just simple image Dockerfile definition to include weewx instalation, it is based on python as base image. It is already preconfigured with timezone and LANG, as my primary goal is to use it in my personal server. If you like it should be possible to override this by setting environments in docker compose but i didn't test it.

Information about weewx software can be found on it's official website: https://weewx.com/

## Example

This repository provide example of simple docker-compose.yaml to show how to run docker image build from this Dockerfile. After first start, docker-entrypoint.sh will ensure creating of default weewx.conf and other files. Please ensure to edit weewx.conf file properly and than start it again. Content of logging.conf must be preserved in end of weewx.conf file to allow it to run inside container properly. Please keep it in mind when replacing weewx.conf with custom file.