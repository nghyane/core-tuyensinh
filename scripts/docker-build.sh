#!/bin/bash

set -e

IMAGE_NAME="ghcr.io/nghyane/core-tuyensinh"
VERSION=${1:-$(git describe --tags --always --dirty)}
PLATFORMS="linux/amd64,linux/arm64"

echo "🚀 Building multi-architecture Docker image..."
echo "📦 Image: $IMAGE_NAME"
echo "🏷️  Version: $VERSION"
echo "🖥️  Platforms: $PLATFORMS"

docker buildx build \
  --platform $PLATFORMS \
  -t $IMAGE_NAME:latest \
  -t $IMAGE_NAME:$VERSION \
  --push \
  -f docker/Dockerfile .

echo "✅ Successfully built and pushed multi-architecture image!"
echo "📋 Available tags:"
echo "   - $IMAGE_NAME:latest"
echo "   - $IMAGE_NAME:$VERSION"

echo "🔍 Image details:"
docker buildx imagetools inspect $IMAGE_NAME:latest 