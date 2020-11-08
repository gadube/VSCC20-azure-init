TAR_URL=https://aka.ms/downloadazcopy-v10-linux
EXE_NAME=azcopy
STORAGE_ID=sccstorageteam15
TOKEN="?st=2020-11-04T12%3A00Z&se=2020-11-12T12%3A00Z&sp=wdl&sv=2018-03-28&ss=b&srt=sco&sig=aqBnS/srk3C9c9rJ3FZbtvIPseLWX1N/rKncVf9FiDQ%3D"

usage(){
	echo "Usage:"
	echo "$0 copy <local files> <remote container>"
	echo "$0 remove <remote container>"
	echo "$0 list <remote container>"
}

# get the file if not already present
if [[ ! -f ${EXE_NAME} ]]; then
	echo "Getting azcopy binary"
	LOCAL_TAR=/tmp/${EXE_NAME}.tar.gz
	wget -O ${LOCAL_TAR} ${TAR_URL} >/dev/null

	tar xzf ${LOCAL_TAR} --strip-components 1 --wildcards **/${EXE_NAME}
fi


case $1 in

	copy)
	./${EXE_NAME} copy $2 "https://${STORAGE_ID}.blob.core.windows.net/$3${TOKEN}" --recursive
	;;

	list)
	 ./${EXE_NAME} list "https://${STORAGE_ID}.blob.core.windows.net/$2${TOKEN}"
	 ;;

	remove)
	 ./${EXE_NAME} remove "https://${STORAGE_ID}.blob.core.windows.net/$2${TOKEN}" --recursive
	 ;;

	*)
	 usage
	 ;;
esac
