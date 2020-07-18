#!/usr/bin/env bash

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright 2020 NetApp
#

IMAGE_TAG=${IMAGE_TAG:-dev}
echo "building container image using tag: '$IMAGE_TAG'";

CWD=$PWD
PROJECT_DIR="$(
  cd "$(dirname "$BASH_SOURCE[0]")/../"
  pwd
)"

cd $PROJECT_DIR
echo "creating image build stamp using git commit sha..."
echo $(git rev-parse HEAD) > terraform/container-build-stamp.txt
echo "starting docker build process..."
docker build -t terraform-rancher:${IMAGE_TAG} .
cd $CWD

