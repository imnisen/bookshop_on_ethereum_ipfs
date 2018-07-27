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

    <div>
      <Modal
        v-model="showModal"
        title="Confirm books to buy"
        loading
        @on-ok="ok"
        @on-cancel="cancel">
        <p>Id:   {{bookToBuy.id}}</p>
        <p>Name:   {{bookToBuy.name}}</p>
        <p>Price:   {{bookToBuy.price}}</p>
        <p>Publisher:   {{bookToBuy.publisher}}</p>
      </Modal>
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
        },
        {
          title: 'Action',
          key: 'action',
          width: 150,
          align: 'center',
          render: (h, params) => {
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
                    this.createOrder(params.index)
                  }
                }
              }, 'Buy'),

            ]);
          }
        }
      ],
      allBooksData: [],
      showModal: false,
      bookToBuy:{
        id: null,
        name: null,
        price: null,
        publisher: null,
      },

    }
  },
  created() {
    this.account = sessionStorage.getItem("account");
    this.getBooks()
  },

  methods: {
    getBooks() {

      this.myBooksData = []
      this.allBooksData = []


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


    createOrder(index) {
      this.showModal = true;
      this.bookToBuy.id = this.allBooksData[index].id;
      this.bookToBuy.name = this.allBooksData[index].name;
      this.bookToBuy.price = this.allBooksData[index].price;
      this.bookToBuy.publisher = this.allBooksData[index].publisher;
    },
    ok(){
      this.makeOrder(this.account, this.bookToBuy.publisher,this.bookToBuy.price, this.bookToBuy.id)
    },
    cancel(){

    },
    makeOrder(buyer, seller, price, bookIndex) {
      this.contract.deployed().then(i => {
        i.makeOrder(buyer, seller, price, bookIndex, {from: this.account})
          .then(res => {
            console.log(res);
            this.showModal=false;
            this.$Message.info('Create order successfully');
          }).catch(e => {
          console.error(e.message);
          this.showModal=false;
          this.$Message.error('Unable to create order');
        });



      })
    },


  }


}
</script>

<style scoped>

</style>
