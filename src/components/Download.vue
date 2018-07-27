<template>

  <div>
    <Form :model="formDownload" :label-width="80">

      <FormItem label="Order Id">
        <Input v-model="formDownload.orderId" style="width: 300px" ></Input>
      </FormItem>
      <FormItem label="Private Key">
        <Input v-model="formDownload.privateKey" placeholder="Place your private key..." style="width: 300px" type="textarea" autosize></Input>
      </FormItem>
      <FormItem>
        <div style="margin-bottom: 10px">
          <Spin v-show="showPin"></Spin>
          <Icon v-show="showDown" type="ios-checkmark" size="20"></Icon>
          <Icon v-show="showFail" type="ios-close" size="20"></Icon>
          <a v-if="downLoadLinkShow" :href="href" :download="fileName">Download Link</a>
        </div>

        <Button type="primary" @click="handleSubmit('formDownload')">Generate Download Link</Button>
        <Button type="ghost" @click="handleReset('formDownload')" style="margin-left: 8px">Reset</Button>
      </FormItem>
    </Form>

  </div>
</template>
<script>/* eslint-disable */

import Buffer from 'buffer'
import IPFS from "ipfs-api"
const buffer = Buffer;

const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

import forge from 'node-forge'

export default {

  name: "Download",
  // 从bookShop传入的值
  data() {
    return {
      formDownload: {
        orderId: null,
        privateKey: null,
      },
      href: null,
      fileName: null,
      downLoadLinkShow: false,

      showPin: false,
      showDown: false,
      showFail: false,
    }
  },
  created() {
    this.account = sessionStorage.getItem("account");
  },
  methods: {

    // orderId -> goodsHash, aesKey, aesIv
    // aesKey+privateKey -> aesKey
    // aesKey+aesIv + ipfs(goodsHash) -> fileOrigin
    // save to local
    handleSubmit(name) {
      this.showPin = true;
      this.showDown = false;
      this.showFail = false;

    var orderId = this.formDownload.orderId;
    var account = this.account;
    var privateKey = this.formDownload.privateKey;
    var goodsHash,aesKey, aesIv, bookIndex, bookName;
    const _this = this;

      this.contract.deployed().then(i => {
        i.getOrder(orderId, {from: account}).then(res=>{
          console.log("getOrder", res);
          goodsHash = res[6];
          bookIndex = res[4];
          i.getOrder2(orderId, {from: account}).then(res=>{
            console.log("getOrder2", res);
            aesKey = res[0]
            aesIv = res[1]

            i.getBook(bookIndex.toNumber(), {from: this.account})
              .then(r => {
                bookName = r[1];

              var privKey = forge.pki.privateKeyFromPem(privateKey);
              var aesKeyDecrypted = privKey.decrypt(aesKey);


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
                _this.href = window.URL.createObjectURL(blob);
                _this.fileName = bookName;
                console.log(_this.href)

                _this.downLoadLinkShow = true;

                _this.showPin = false;
                _this.showDown = true;
              })
            })
          })

        })
      })

    },

    handleReset(name) {
      this.$refs[name].resetFields();
    },






  }
}
</script>

<style scoped>
  h1,
  h2 {
    font-weight: normal;
  }

  ul {
    list-style-type: none;
    padding: 0;
  }

  li {
    display: inline-block;
    margin: 0 10px;
  }

  a {
    color: #42b983;
  }
</style>
