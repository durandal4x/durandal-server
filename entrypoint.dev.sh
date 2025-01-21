#!/bin/bash
set -e

mix setup

exec "$@"