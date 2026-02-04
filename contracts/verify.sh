#!/bin/bash

# Load env
set -a
source ../.env
set +a

echo "🔍 Verifying contracts on Base Sepolia..."
echo ""

# ChallengeEscrow (1 arg: ChallengeFactory)
echo "📋 Verifying ChallengeEscrow..."
npx hardhat verify --network base-sepolia 0xC107f8328712998abBB2cCf559f83EACF476AE82 0xcE1D04A1830035Aa117A910f285818FF1AFca621 --quiet
echo "✅ ChallengeEscrow verified"
echo ""

# ChallengeFactory (3 args)
echo "📋 Verifying ChallengeFactory..."
npx hardhat verify --network base-sepolia 0xcE1D04A1830035Aa117A910f285818FF1AFca621 \
  0xC107f8328712998abBB2cCf559f83EACF476AE82 \
  0xb843A2D0D4B9E628500d2E0f6f0382e063C14a95 \
  0xb843A2D0D4B9E628500d2E0f6f0382e063C14a95 --quiet
echo "✅ ChallengeFactory verified"
echo ""

# PointsEscrow (1 arg)
echo "📋 Verifying PointsEscrow..."
npx hardhat verify --network base-sepolia 0xCfAa7FCE305c26F2429251e5c27a743E1a0C3FAf \
  0xcE1D04A1830035Aa117A910f285818FF1AFca621 --quiet
echo "✅ PointsEscrow verified"
echo ""

echo "🎉 All contracts verified!"
echo "📊 View at: https://sepolia.basescan.org"
