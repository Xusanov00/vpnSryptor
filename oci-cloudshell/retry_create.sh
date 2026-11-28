#!/bin/bash
set +e

COMPARTMENT_ID="$OCI_TENANCY"
AD="JMuG:AP-SINGAPORE-1-AD-1"
SUBNET_ID="ocid1.subnet.oc1.ap-singapore-1.aaaaaaaaq76it5tptbnvnmhvn6pyofmri3sarlq42znlacd335hk77fj7ceq"
IMAGE_ARM="ocid1.image.oc1.ap-singapore-1.aaaaaaaathtfs2mncvrtpigma75a4hzvsyxmvvgqrod5hit6he3p43mv5aiq"
IMAGE_AMD="ocid1.image.oc1.ap-singapore-1.aaaaaaaadywigqfydsbop73cjafcdesxd37eonzpg4bpgh35q4pmvzxenbra"
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTgEDbw4w13MQ9KdtfshDRWfxRiESwf4hFNDrcXOVeAEdPgBTrYUB5Ps/92FGA/vgtnDFPV1j6GBzGDBZXbRmB3HMQ6IwWGrtnFUdfSyhLUmNVijD9PoLA1lwiUsASy8LEYx/ooGIc3ZvsLaqMVENip4z0T6M1k3oqEA1MbSsncIvMTX6BxU26ZWwbxFoeI8N1J95lA8eUfD4o5wU08QaZOABPAdXKS881ybvtOvG9sfHVtEzYLH14vadFQXGF1ARBcGbBZ1hdvBbuFxMrgWB8fOtnPkbLYsXXxM3np8AuVAre6soi8cSfHGtGdbE9tsxB4Eo1O8EhBQOZy1Nse3jV ssh-key-2026-11-27"

ATTEMPT=0
while true; do
  ATTEMPT=$((ATTEMPT + 1))
  TS=$(date '+%Y-%m-%d %H:%M:%S')

  if [ $((ATTEMPT % 2)) -eq 1 ]; then
    SHAPE="VM.Standard.A1.Flex"
    IMAGE="$IMAGE_ARM"
    SHAPE_ARGS=(--shape-config '{"ocpus":1,"memoryInGBs":6}')
  else
    SHAPE="VM.Standard.E2.1.Micro"
    IMAGE="$IMAGE_AMD"
    SHAPE_ARGS=()
  fi

  echo "[$TS] Попытка #$ATTEMPT, shape=$SHAPE..."

  RESULT=$(oci compute instance launch \
    --compartment-id "$COMPARTMENT_ID" \
    --availability-domain "$AD" \
    --shape "$SHAPE" \
    "${SHAPE_ARGS[@]}" \
    --subnet-id "$SUBNET_ID" \
    --image-id "$IMAGE" \
    --display-name "vpn-server-cloudshell" \
    --assign-public-ip true \
    --metadata "{\"ssh_authorized_keys\":\"$SSH_PUBLIC_KEY\"}" \
    --wait-for-state RUNNING \
    --max-wait-seconds 60 \
    2>&1)

  if echo "$RESULT" | grep -qi '"lifecycle-state": "RUNNING"'; then
    echo "УСПЕХ! Инстанс создан."
    echo "$RESULT" | grep -i '"public-ip"'
    echo "$RESULT" > ~/instance_success.json
    break
  else
    SHORT=$(echo "$RESULT" | grep -oE '"code": "[^"]*"' | head -1)
    MSG=$(echo "$RESULT" | grep -oE '"message": "[^"]*"' | head -1)
    echo "  -> неудача: $SHORT, $MSG"
  fi

  sleep 90
done
