<template>
  <div>

    <Publish @newBookPublished="getBooks"></Publish>

    <br/>
    <br/>

    <div>
      <div>My Published Books</div>
      <Table border stripe :columns="myBooksColumns" :data="myBooksData"></Table>
    </div>

    <br/>
    <br/>

    <div>
      <div>All Other Published Books</div>
      <Table border stripe :columns="allBooksColumns" :data="allBooksData"></Table>
    </div>


  </div>
</template>

<script>/* eslint-disable */
import Publish from './Publish'

export default {
  name: "Books",
  components: {Publish},
  data() {
    return {

      myBooksColumns: [
        {
          title: 'Book Id',
          key: 'id'
        },
        {
          title: 'Book Name',
          key: 'name'
        },
        {
          title: 'Book Price',
          key: 'price'
        }
      ],
      myBooksData: [],


      allBooksColumns: [
        {
          title: 'Book Id',
          key: 'id'
        },
        {
          title: 'Book Name',
          key: 'name'
        },
        {
          title: 'Book Price',
          key: 'price'
        },
        {
          title: 'Publisher',
          key: 'publisher'
        }
      ],
      allBooksData: [],


    }
  },
  created() {
    this.account = sessionStorage.getItem("account");
    this.getBooks()
  },

  methods: {
    getBooks() {
      this.contract.deployed()
        .then(i => {
          // get my books
          console.log(this.account);
          i.getUserBooks(this.account, {from: this.account})
            .then(res => {

              res.forEach(bookId => {
                i.getBook(bookId.toNumber(), {from: this.account})
                  .then(r => {
                    this.myBooksData.push({
                      "id": r[0].toNumber(),
                      "name": r[1],
                      "price": r[2].toNumber(),
                    })
                  })

              });
              console.log("afterall : myBooks", this.myBooksData)
            })
          console.log('debug');
          // get all books
          i.getUsers({from: this.account}).then(res => {
            res.forEach(userAddress => {
              if (userAddress !== this.account) {
                i.getUserBooks(userAddress, {from: this.account}).then(bookIds => {
                  bookIds.forEach(id => {
                    i.getBook(id.toNumber(), {from: this.account}).then(r => {
                      this.allBooksData.push({
                        "id": r[0].toNumber(),
                        "name": r[1],
                        "price": r[2].toNumber(),
                        "publisher": userAddress,
                      })
                    })
                  })
                })
              }

            });

            console.log("afterall : userBooks", this.allBooksData)


          })


        })
        .catch(e => {
          console.error(e.message);
        });
    },

  }


}
</script>

<style scoped>

</style>
