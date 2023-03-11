# Bitcoin block cost basis

This repository contains market price data for each Bitcoin block.

The Kraken exchange API is used to query USD market data during the minute the block was mined. The one minute time scale is used, which stores the `open`, `high`, `low`, `close` prices for that minute.

This data can be useful calculating mining cost basis data.

**Only blocks since height 769835 have been added. Historical data will be added a little at a time.**

## USD Market data

USD market price details are stored in CSV and JSON formats in the `data/cost-basis` directory. The file name is set to the exchange name to identify the source of the market data.

CSV format - `data/cost-basis/kraken.csv`

```text
height,timestamp,open,high,low,close
769835,1672556807,16517.65,16520.03,16517.65,16519.85
769836,1672556829,16519.85,16520.25,16517.66,16518.24
769837,1672556915,16518.24,16520.8,16518.24,16520.8
769838,1672557644,16499.91,16500.03,16498.61,16499.14
```

JSON format - `data/cost-basis/kraken.json`

```json
[
  {
    "height": 769835,
    "timestamp": 1672556807,
    "open": 16517.65,
    "high": 16520.03,
    "low": 16517.65,
    "close": 16519.85
  },
  {
    "height": 769836,
    "timestamp": 1672556829,
    "open": 16519.85,
    "high": 16520.25,
    "low": 16517.66,
    "close": 16518.24
  },
  {
    "height": 769837,
    "timestamp": 1672556915,
    "open": 16518.24,
    "high": 16520.8,
    "low": 16518.24,
    "close": 16520.8
  },
  {
    "height": 769838,
    "timestamp": 1672557644,
    "open": 16499.91,
    "high": 16500.03,
    "low": 16498.61,
    "close": 16499.14
  }
]
```

## Bitcoin block data

Bitcoin block data is stored in CSV and JSON formats in the `data/blocks` directory.

CSV format - `data/blocks/btc.csv`

```text
id,height,version,timestamp,tx_count,size,weight,merkle_root,previousblockhash,mediantime,nonce,bits,difficulty
0000000000000000000112c77e457abc829e115cb2d7fd2a481f478de773630b,769835,536879108,1672556807,870,612078,1364730,46904b9603b8955d70240a5328a9863eefbb3b22ad67c9a7cff9b44c52e422f4,00000000000000000002e57a53063f0668b32382813616b505466f5f7a06a076,1672554410,3604203011,386397584,35364065900457.12
00000000000000000006e05461cd306bda4d5af7ac290e42612bde19a2fa35b5,769836,660815876,1672556829,17,6130,15601,fe83163a3e1e04125e2aa8bae5e2b6a67028d9862cb84f92a8dd95821627efe5,0000000000000000000112c77e457abc829e115cb2d7fd2a481f478de773630b,1672554989,1506880630,386397584,35364065900457.12
00000000000000000005ff8cb9a90a4ab4b237e7edc7c9bdff3bc6d24043eaa5,769837,760094724,1672556915,168,88514,220373,26df49be58a81809cbe50e3e6510a290ace43930b2d1cf0e7d6c9d793d8a1015,00000000000000000006e05461cd306bda4d5af7ac290e42612bde19a2fa35b5,1672555154,2248241211,386397584,35364065900457.12
00000000000000000000d256db795e5e65d9a1d965ed3ffdbcd8867ebb4866a8,769838,536870912,1672557644,1253,1445928,3363513,3261207a89b06757d641b5891a21898620622dfb3c18b89a8375f6dbfc46ff42,00000000000000000005ff8cb9a90a4ab4b237e7edc7c9bdff3bc6d24043eaa5,1672555654,226309823,386397584,35364065900457.12
```

JSON format - `data/blocks/btc.json`

```json
[
  {
    "id": "0000000000000000000112c77e457abc829e115cb2d7fd2a481f478de773630b",
    "height": 769835,
    "version": 536879108,
    "timestamp": 1672556807,
    "tx_count": 870,
    "size": 612078,
    "weight": 1364730,
    "merkle_root": "46904b9603b8955d70240a5328a9863eefbb3b22ad67c9a7cff9b44c52e422f4",
    "previousblockhash": "00000000000000000002e57a53063f0668b32382813616b505466f5f7a06a076",
    "mediantime": 1672554410,
    "nonce": 3604203011,
    "bits": 386397584,
    "difficulty": "35364065900457.12"
  },
  {
    "id": "00000000000000000006e05461cd306bda4d5af7ac290e42612bde19a2fa35b5",
    "height": 769836,
    "version": 660815876,
    "timestamp": 1672556829,
    "tx_count": 17,
    "size": 6130,
    "weight": 15601,
    "merkle_root": "fe83163a3e1e04125e2aa8bae5e2b6a67028d9862cb84f92a8dd95821627efe5",
    "previousblockhash": "0000000000000000000112c77e457abc829e115cb2d7fd2a481f478de773630b",
    "mediantime": 1672554989,
    "nonce": 1506880630,
    "bits": 386397584,
    "difficulty": "35364065900457.12"
  },
  {
    "id": "00000000000000000005ff8cb9a90a4ab4b237e7edc7c9bdff3bc6d24043eaa5",
    "height": 769837,
    "version": 760094724,
    "timestamp": 1672556915,
    "tx_count": 168,
    "size": 88514,
    "weight": 220373,
    "merkle_root": "26df49be58a81809cbe50e3e6510a290ace43930b2d1cf0e7d6c9d793d8a1015",
    "previousblockhash": "00000000000000000006e05461cd306bda4d5af7ac290e42612bde19a2fa35b5",
    "mediantime": 1672555154,
    "nonce": 2248241211,
    "bits": 386397584,
    "difficulty": "35364065900457.12"
  },
  {
    "id": "00000000000000000000d256db795e5e65d9a1d965ed3ffdbcd8867ebb4866a8",
    "height": 769838,
    "version": 536870912,
    "timestamp": 1672557644,
    "tx_count": 1253,
    "size": 1445928,
    "weight": 3363513,
    "merkle_root": "3261207a89b06757d641b5891a21898620622dfb3c18b89a8375f6dbfc46ff42",
    "previousblockhash": "00000000000000000005ff8cb9a90a4ab4b237e7edc7c9bdff3bc6d24043eaa5",
    "mediantime": 1672555654,
    "nonce": 226309823,
    "bits": 386397584,
    "difficulty": "35364065900457.12"
  }
]
```

Data added automatically is from the [Blockstream API](https://blockstream.info/).

Historical block data is added from a local (to the developer) full node.

### Keeping data up to date

Two GitHub Action workflows keep the block and price data up to date each day.

One workflow adds new blocks and the other adds price data.

## License

[MIT license](./LICENSE)

Copyright (c) 2023 Rock Creek Technologies LLC
