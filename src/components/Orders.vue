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
  data() {
    return {
      refresh: false,
      myBuyData: [],
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
          title: 'Order Closed',
          key: 'closed'
        },
        {
          title: 'Order Success',
          key: 'success'
        },

        {
          title: 'Action',
          key: 'action',
          width: 200,
          align: 'center',
          render: (h, params) => {

            if (this.refresh) {

            }
            if (this.myBuyData[params.index].closed) {
              if (this.myBuyData[params.index].success) {

                console.log("bbb", this.myBuyData[params.index].showDownloadLink)
                if (this.myBuyData[params.index].showDownloadLink) {
                  return h('a', {
                    attrs: {
                      href: this.myBuyData[params.index].href,
                      download: this.myBuyData[params.index].download
                    }
                  }, "Download")
                } else {

                  return h('div', [
                    h('Button', {
                      props: {
                        type: 'primary',
                        size: 'small'
                      },
                      style: {
                        marginRight: '5px'
                      },
                      on: {
                        click: () => {

                          this.$Modal.confirm({
                            okText: 'OK',
                            cancelText: 'Cancel',
                            loading: true,
                            render: (h) => {
                              return h('Input', {
                                props: {
                                  value: myPrivateKey,
                                  autofocus: true,
                                  placeholder: 'Please enter your private key to confirm order',
                                  type: "textarea",
                                  autosize: true,
                                },
                                on: {
                                  input: (val) => {
                                    myPrivateKey = val;
                                  },
                                }
                              })
                            },

                            onOk: () => {
                              console.log('myPrivateKey', myPrivateKey)
                              console.log('params.index', params.index)
                              console.log('params.index', this.myBuyData[params.index].id)
                              this.generateDownloadLink(this.myBuyData[params.index].id,
                                this.account,
                                myPrivateKey,
                                params.index
                              )
                            }
                          })
                        }
                      }
                    }, 'Generate Download Link'),
                  ]);
                }
              } else {
                return h('Icon', {
                  props: {
                    type: "close",
                  }
                })
              }
            }
          }
        }
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
          title: 'Order Closed',
          key: 'closed'
        },
        {
          title: 'Order Success',
          key: 'success'
        },
        {
          title: 'Action',
          key: 'action',
          width: 200,
          align: 'center',
          render: (h, params) => {
            console.log("this.mySellData[params.index].closed", this.mySellData[params.index].closed)
            if (this.mySellData[params.index].closed) {
              return h('Icon', {
                props: {
                  type: "checkmark"
                }
              })
            }
            else {
              return h('div', [
                h('Button', {
                  props: {
                    type: 'primary',
                    size: 'small'
                  },
                  style: {
                    marginRight: '5px'
                  },
                  on: {
                    click: () => {

                      this.$Modal.confirm({
                        okText: 'OK',
                        cancelText: 'Cancel',
                        loading: true,
                        render: (h) => {
                          return h('Input', {
                            props: {
                              value: this.myPrivateKey,
                              autofocus: true,
                              placeholder: 'Please enter your private key to confirm order',
                              type: "textarea",
                              autosize: true,
                            },
                            on: {
                              input: (val) => {
                                this.myPrivateKey = val;
                              },
                            }
                          })
                        },

                        onOk: () => {
                          console.log('this.myPrivateKey', this.myPrivateKey)
                          console.log('params.index', params.index)
                          console.log('params.index', this.mySellData[params.index].id)

                          this.approveOrderId = this.mySellData[params.index].id
                          this.approveOrder()
                        }
                      })
                    }
                  }
                }, 'Accept'),
                h('Button', {
                  props: {
                    type: 'error',
                    size: 'small'
                  },
                  on: {
                    click: () => {
                      this.$Modal.confirm({
                        title: 'Confirm decline this order',
                        content: '<p>Sure to decline?</p>',
                        okText: 'OK',
                        cancelText: 'Cancel',
                        loading: true,
                        onOk: () => {
                          console.log('this.myPrivateKey', this.myPrivateKey)
                          console.log('params.index', params.index)
                          console.log('params.index', this.mySellData[params.index].id)

                          this.declineOrderId = this.mySellData[params.index].id
                          this.declineOrder()
                        }
                      })


                    }
                  }
                }, 'Decline'),

              ]);
            }
          }
        }
      ],


      approveOrderId: null,
      myPrivateKey: null,
      declineOrderId: null,

    }
  },
  created() {
    this.account = sessionStorage.getItem("account");
    this.getOrders();
  },
  methods: {
    getOrders() {
      this.getUserSellOrders();
      this.getUserBuyOrders();
    },
    getUserBuyOrders() {
      this.myBuyData = [];
      this.contract.deployed().then(i => {
        i.getUserBuyOrders({from: this.account})
          .then(res => {
            console.log("getUserBuyOrders", res);
            res.forEach(orderId => {
              i.getOrder(orderId, {from: this.account}).then(r => {

                i.getOrder2(orderId, {from: this.account}).then(r2 => {

                  this.myBuyData.push({
                    "id": r[0].toNumber(),
                    "buyer": r[1],
                    "seller": r[2],
                    "price": r[3].toNumber(),
                    "bookIndex": r[4].toNumber(),
                    "closed": r[5],
                    "success": r2[3],
                  })
                })
              })
            })

          }).catch(e => {
          console.error(e.message);
        });
      })
    },

    getUserSellOrders() {
      this.mySellData = [];
      this.contract.deployed().then(i => {
        i.getUserSellOrders({from: this.account})
          .then(res => {
            console.log("getUserSellOrders", res);
            res.forEach(orderId => {
              i.getOrder(orderId, {from: this.account}).then(r => {
                i.getOrder2(orderId, {from: this.account}).then(r2 => {
                  this.mySellData.push({
                    "id": r[0].toNumber(),
                    "buyer": r[1],
                    "seller": r[2],
                    "price": r[3].toNumber(),
                    "bookIndex": r[4].toNumber(),
                    "closed": r[5],
                    "success": r2[3],
                  })
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
    approveOrder() {
      myPrivateKey = this.myPrivateKey;
      myApproveorderId = this.approveOrderId;
      var myAccount = this.account

      const _this = this;

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
              console.log('bookId', bookId)
              i.getBook(bookId.toNumber(), {from: this.account}).then(res => {
                console.log("getBook", res);
                var bookHash = res[5];
                var aesKey1 = res[3];
                var aesIv1 = res[4];

                console.log("aesKey1", aesKey1);

                // get from IPFS
                ipfs.files.get(bookHash, function (err, files) {

                  console.log('files', files);

                  var fileEncrypted1 = files[0]
                  console.log('bookEncrypted', fileEncrypted1);
                  var fileEncrypted1Content = fileEncrypted1.content
                  console.log('fileEncrypted1Content', fileEncrypted1Content);

                  console.log(myPrivateKey)
                  var sellerPrivateKey = forge.pki.privateKeyFromPem(myPrivateKey);
                  console.log("---aesKey1-----", aesKey1);
                  var aesKeyDecrypted = sellerPrivateKey.decrypt(aesKey1)

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
                    if (err) {
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
                        _this.$Modal.remove();
                        _this.$Message.info('Approve success');
                        setTimeout(() => {
                          _this.getOrders();
                        }, 2000);
                      })
                  })
                })
              }).catch(e => {
                console.error(e.message);
                _this.$Modal.remove();
                _this.$Message.info('Approve failed');
                _this.getOrders();
              });
            }).catch(e => {
              console.error(e.message);
              _this.$Modal.remove();
              _this.$Message.info('Approve failed');
              _this.getOrders();
            });
          }).catch(e => {
          console.error(e.message);
          _this.$Modal.remove();
          _this.$Message.info('Approve failed');
          _this.getOrders();
        });
      })
    },

    declineOrder() {
      this.contract.deployed().then(i => {
        i.declineOrder(this.declineOrderId, {from: this.account})
          .then(res => {
            console.log(res);

            this.$Modal.remove();
            this.$Message.info('Decline success');

          }).catch(e => {
          console.error(e.message);

          this.$Modal.remove();
          this.$Message.info('Decline failed');

        });
      })
    },

    // Download book
    generateDownloadLink(orderId, account, privateKey, showLinkIndex) {

      var goodsHash, aesKey, aesIv, bookIndex, bookName;
      const _this = this;
      this.contract.deployed().then(i => {
        i.getOrder(orderId, {from: account}).then(res => {
          console.log("getOrder", res);
          goodsHash = res[6];
          console.log("goodsHash", goodsHash);
          bookIndex = res[4];
          i.getOrder2(orderId, {from: account}).then(res => {
            console.log("getOrder2", res);
            aesKey = res[0]
            aesIv = res[1]

            i.getBook(bookIndex.toNumber(), {from: this.account})
              .then(r => {
                bookName = r[1];

                console.log("privateKey", privateKey);
                var privKey = forge.pki.privateKeyFromPem(privateKey);
                console.log('privateKey2', privKey);
                console.log('aesKey', aesKey);
                var aesKeyDecrypted = privKey.decrypt(aesKey);
                console.log('aesKeyDecrypted', aesKeyDecrypted);

                console.log('goodsHash', goodsHash);
                ipfs.files.get(goodsHash, function (err, files) {
                  console.log('files', files);

                  var fileEncrypted = files[0]
                  console.log('bookEncrypted', fileEncrypted);
                  var fileEncryptedContent = fileEncrypted.content;
                  console.log('fileEncryptedContent', fileEncryptedContent);

                  // decrpt
                  var decipher = forge.cipher.createDecipher('AES-CBC', aesKeyDecrypted);
                  decipher.start({iv: aesIv});

                  // node buffer -> forge buffer
                  var fbuffer = forge.util.createBuffer(fileEncryptedContent.toString('binary'))
                  console.log("fbuffer", fbuffer)
                  decipher.update(fbuffer);
                  var result = decipher.finish(); // check 'result' for true/false

                  var fileOrigin = decipher.output;
                  console.log("fileOrigin", fileOrigin);

                  //transfer fileOrigin
                  var nBuffer = buffer.Buffer(fileOrigin.getBytes(), 'binary');
                  console.log("nBuffer", nBuffer)

                  // save file
                  var blob = new Blob([nBuffer], {type: 'application/octet-stream'})
                  _this.myBuyData[showLinkIndex].href = window.URL.createObjectURL(blob);
                  _this.myBuyData[showLinkIndex].download = bookName;
                  _this.myBuyData[showLinkIndex].showDownloadLink = true;

                  console.log('aaa')
                  console.log(_this.myBuyData[showLinkIndex].href)
                  console.log(_this.myBuyData[showLinkIndex].download)
                  console.log(_this.myBuyData[showLinkIndex].showDownloadLink)
                  console.log(_this.myBuyData)
                  _this.refresh = !_this.refresh

                  _this.$Modal.remove();
                  _this.$Message.info('Generate download link success');

                })
              })
            //   .catch(e => {
            //   console.error(e.message);
            //   _this.$Modal.remove();
            //   _this.$Message.info('Generate download link fail');
            // });
          })
          //   .catch(e => {
          //   console.error(e.message);
          //   _this.$Modal.remove();
          //   _this.$Message.info('Generate download link fail');
          // });

        })
        //   .catch(e => {
        //   console.error(e.message);
        //   _this.$Modal.remove();
        //   _this.$Message.info('Generate download link fail');
        // });
      })
      //   .catch(e => {
      //   console.error(e.message);
      //   _this.$Modal.remove();
      //   _this.$Message.info('Generate download link fail');
      // });
    }

  }

}
</script>

<style scoped>

</style>
