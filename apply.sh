if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <script_folder>"
	exit 1
fi

SCRIPT_FOLDER="$1"

if [ ! -d "$SCRIPT_FOLDER" ]; then
	echo "Error: Directory '$SCRIPT_FOLDER' does not exist."
	exit 1
fi

declare -A CONTAINER_BY_HOSTNAME_MAP
for id in $(docker ps -q); do
	hostname=$(docker inspect -f '{{.Config.Hostname}}' $id)
	CONTAINER_BY_HOSTNAME_MAP[$hostname]=$id
done

for script in "$SCRIPT_FOLDER"/*.sh; do
	if [ -f "$script" ]; then
		echo "Applying script: $script"
		hostname=$(basename "$script" .sh)
		if [[ -n "${CONTAINER_BY_HOSTNAME_MAP[$hostname]}" ]]; then
			container_id=${CONTAINER_BY_HOSTNAME_MAP[$hostname]}
			cat "$script" | docker exec -i "$container_id" sh
			echo "Script '$script' applied to container with hostname '$hostname'."
		else
			echo "Warning: No container found for hostname '$hostname'. Skipping script."
		fi
	fi
done