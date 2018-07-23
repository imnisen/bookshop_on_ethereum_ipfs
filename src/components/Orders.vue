<template>
  <div>
    <!--my buy orders-->
    <div>
      <div>My Buy Orders</div>
      <Table stripe :columns="myBuyColumns" :data="myBuyData"></Table>
    </div>

    <br/>
    <br/>

    <div>
      <div>My Sell Orders</div>
      <Table stripe :columns="mySellColumns" :data="mySellData"></Table>
    </div>

    <br/>
    <br/>
    <br/>

    <!--Approve Order-->

    <div>
      <Input v-model="approveOrderId" placeholder="Place your approveOrderId ..." style="width: 300px"></Input>
      <Input v-model="myPrivateKey" placeholder="Place your Private Key ..." type="textarea" autosize style="width: 300px"></Input>
      <Button @click="approveOrder()">Approve Order</Button>
    </div>

    <br/>
    <br/>
    <br/>

    <!--declineOrder-->
    <div>
      <Input v-model="declineOrderId" placeholder="Place your declineBuyId ..." style="width: 300px"></Input>
      <Button @click="declineOrder()">Decline Buy</Button>
    </div>

  </div>

</template>

<script>/* eslint-disable */
  import Buffer from 'buffer'
  import IPFS from "ipfs-api"
  import forge from 'node-forge'

  const buffer = Buffer;
  const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

  var myPrivateKey;
  var myApproveorderId;

    export default {
        name: "Orders",
      props: [
        "contract",
        "account"
      ],
      data() {
        return {
          myBuyColumns: [
            {
              title: 'Order Id',
              key: 'id'
            },
            {
              title: 'Buyer',
              key: 'buyer'
            },
            {
              title: 'Seller',
              key: 'buyer'
            },
            {
              title: 'Order Price',
              key: 'price'
            },
            {
              title: 'Book Index',
              key: 'bookIndex'
            },
            {
              title: 'Order Finished',
              key: 'closed'
            },
          ],
          mySellData: [],
          mySellColumns: [
            {
              title: 'Order Id',
              key: 'id'
            },
            {
              title: 'Buyer',
              key: 'buyer'
            },
            {
              title: 'Seller',
              key: 'buyer'
            },
            {
              title: 'Order Price',
              key: 'price'
            },
            {
              title: 'Book Index',
              key: 'bookIndex'
            },
            {
              title: 'Order Finished',
              key: 'closed'
            },
          ],
          myBuyData: [],

          approveOrderId: null,
          myPrivateKey: null,
          declineOrderId: null
        }
      },
      created() {
        this.getUserSellOrders();
        this.getUserBuyOrders();
      },
      methods: {
        getUserBuyOrders () {
          this.contract.deployed().then(i => {
            i.getUserBuyOrders({from: this.account})
              .then(res => {
                console.log("getUserBuyOrders", res);

                res.forEach(orderId => {
                  i.getOrder(orderId, {from: this.account}).then(r=>{

                    this.myBuyData.push({
                      "id": r[0],
                      "buyer": r[1],
                      "seller": r[2],
                      "price": r[3],
                      "bookIndex": r[4],
                      "closed": r[5],
                    })
                  })
                })

              }).catch(e => {
              console.error(e.message);

            });
          })
        },

        getUserSellOrders () {
          this.contract.deployed().then(i => {
            i.getUserSellOrders({from: this.account})
              .then(res => {
                console.log("getUserSellOrders", res);

                res.forEach(orderId => {
                  i.getOrder(orderId, {from: this.account}).then(r=>{

                    this.mySellData.push({
                      "id": r[0],
                      "buyer": r[1],
                      "seller": r[2],
                      "price": r[3],
                      "bookIndex": r[4],
                      "closed": r[5],
                    })
                  })
                })

              }).catch(e => {
              console.error(e.message);
            });
          })
        },


        // Have: orderId, Private key(UI provided)
        // orderId->BookId->bookHash,aesKey, aesIv
        //        ->buyerPublicKey
        // From IPFS get bookHash -> bookEncrypted
        // Use Private key to decrypted aesKey -> new aesKey
        // Use new aesKey aesIv decrypted bookEncrypted -> book Origin
        // Generate new2 aeskey, aesIv
        // encrypt book Origin with new2 aeskey, aesIv -> new2 bookEncrypted
        // encrypt new2 aeskey with buyer's public key -> new2 aeskey encrypted
        // Upload new2 bookEncrypted to ipfs-> IFPS hash
        // Call contract with: IFPS hash, new2 aeskey encrypted, new2 aesIv
        approveOrder () {
          myPrivateKey = this.myPrivateKey;
          myApproveorderId = this.approveOrderId;
          var myAccount =  this.account
          this.contract.deployed().then(i => {
            console.log("this.approveOrderId", this.approveOrderId)
            console.log("this.account", this.account)
            i.getOrder(this.approveOrderId, {from: this.account})
              .then(res => {
                console.log(res);

                var bookId = res[4];

                i.getOrder2(this.approveOrderId, {from: this.account}).then(res2 => {
                  console.log("getOrder2", res2);
                  var buyerPublicKey = res2[2]


                  i.getBook(bookId, {from: this.account}).then(res => {
                    console.log("getBook", res);
                    var bookHash = res[5];
                    var aesKey1 = res[3];
                    var aesIv1 = res[4];


                    // get from IPFS
                    ipfs.files.get(bookHash, function (err, files) {

                      console.log('files', files);

                      var fileEncrypted1 = files[0]
                      console.log('bookEncrypted', fileEncrypted1);
                      var fileEncrypted1Content = fileEncrypted1.content
                      console.log('fileEncrypted1Content', fileEncrypted1Content);


                      console.log(myPrivateKey)
                      var sellerPrivateKey = forge.pki.privateKeyFromPem(myPrivateKey);
                      console.log("aesKey1", aesKey1)
                      var aesKeyDecrypted =  sellerPrivateKey.decrypt(aesKey1)

                      console.log("aesKeyDecrypted", aesKeyDecrypted)
                      var decipher = forge.cipher.createDecipher('AES-CBC', aesKeyDecrypted);
                      decipher.start({iv: aesIv1});

                      // node buffer -> forge buffer
                      var fbuffer = forge.util.createBuffer(fileEncrypted1Content.toString('binary'))
                      console.log("fbuffer", fbuffer)
                      decipher.update(fbuffer);
                      var result = decipher.finish(); // check 'result' for true/false

                      var fileOrigin = decipher.output;
                      console.log("fileOrigin", fileOrigin);


                      var aesKey2 = forge.random.getBytesSync(16);
                      var aesIv2 = forge.random.getBytesSync(16);


                      var cipher = forge.cipher.createCipher('AES-CBC', aesKey2);
                      cipher.start({iv: aesIv2});
                      cipher.update(forge.util.createBuffer(fileOrigin));
                      cipher.finish();
                      var fileEncrypted2 = cipher.output;
                      console.log("fileEncrypted2", fileEncrypted2);


                      console.log("buyerPublicKey", buyerPublicKey)
                      var buyerPubKey = forge.pki.publicKeyFromPem(buyerPublicKey)
                      var aesKey2Encrypted = buyerPubKey.encrypt(aesKey2);

                      var nodeBuffer = buffer.Buffer(fileEncrypted2.getBytes(), 'binary');
                      ipfs.files.add(nodeBuffer, (err, result) => {
                        if(err) {
                          console.error(err);
                          return
                        }

                        let url = `https://ipfs.io/ipfs/${result[0].hash}`;
                        console.log(`Url --> ${url}`);

                        console.log("result[0].hash", result[0].hash)
                        console.log("aesKey2Encrypted", aesKey2Encrypted)
                        console.log("aesIv2", aesIv2)
                        i.approveOrder(myApproveorderId, result[0].hash, aesKey2Encrypted, aesIv2, {from: myAccount})
                          .then(res => {
                            console.log("approveOrder res", res)
                          })
                      })





                    })







                  })
                })


              }).catch(e => {
              console.error(e.message);
            });
          })

        },







        // need add logic
        declineOrder () {
          this.contract.deployed().then(i => {
            i.declineOrder(this.declineOrderId, {from: this.account})
              .then(res => {
                console.log(res);



              }).catch(e => {
              console.error(e.message);



            });
          })
        },

      }

    }
</script>

<style scoped>

</style>
