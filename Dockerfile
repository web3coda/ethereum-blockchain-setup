# Pull Docker image of official golang ethereum implementation 
FROM ethereum/client-go:stable

# Generate a new account (to pre-fund) using "password123" password
RUN echo password123 > /root/password.txt \
    && geth account new --password /root/password.txt | grep "Public address of the key" | awk '{print substr($NF, 3)}' > /root/account \
    && cat /root/.ethereum/keystore/*

# Copy genesis.json file to /tmp
# Genesis file defined genesis block. Official documentation: https://geth.ethereum.org/docs/fundamentals/private-network
COPY genesis.json /tmp

# Putting newly generated account address in Genesis to ensure initial allocation 
RUN account_address=$(cat /root/account) \
    && echo ${account_address} \
    && sed -i "s/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/${account_address}/g" /tmp/genesis.json \
    && cat /tmp/genesis.json

# Initializing geth
RUN geth init /tmp/genesis.json \
    && rm -f ~/.ethereum/geth/nodekey

# Generate a new account (to use for miner) using "password123" password
RUN geth account new --password /root/password.txt \
    && cat /root/.ethereum/keystore/*

ENTRYPOINT ["geth"]
