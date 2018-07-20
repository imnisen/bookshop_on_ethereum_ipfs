<template>
  <div>
  <div>
    <div>my books</div>
    <ul>
      <li v-for="book in myBooks">
        Id: {{ book.id }} | Name:{{ book.name }} | Price:{{ book.price }}
      </li>
    </ul>

  </div>

  <br/>
  <br/>

  <div>
    <div>All books in system</div>
    <ul>
      <li v-for="user in allBooks">

        <div>user: {{user.address}}</div>
        <ul>
          <li v-for="book in user.books">
            Id: {{ book.id }} | Name:{{ book.name }} | Price:{{ book.price }}
          </li>
        </ul>

      </li>
    </ul>

  </div>
  </div>
</template>

<script>/* eslint-disable */
  export default {
    name: "Books",
    props: [
      "contract",
      "account"
    ],
    data() {
      return {
        myBooks: [],
        allBooks: [],
      }
    },
    created() {
      this.getBooks()
    },

    methods: {
      getBooks() {
        this.contract.deployed()
          .then(i => {

            // get my books
            i.getUserBooks(this.account, {from: this.account})
              .then(res => {
                this.myBooks = [];

                res.forEach(bookId => {
                  i.getBook(bookId.toNumber(), {from: this.account})
                    .then(r => {
                      this.myBooks.push({
                        "id": r[0].toNumber(),
                        "name": r[1],
                        "price": r[2].toNumber(),
                      })
                    })

                })

                console.log("afterall : myBooks", this.myBooks)

              })


            // get all books
            i.getUsers({from: this.account}).then(res => {
              this.allBooks = [];

              res.forEach(userAddress => {
                var userBooks = [];

                i.getUserBooks(userAddress, {from: this.account}).then(bookIds => {
                  bookIds.forEach(id => {
                    i.getBook(id.toNumber(), {from: this.account}).then(r => {
                      userBooks.push({
                        "id": r[0].toNumber(),
                        "name": r[1],
                        "price": r[2].toNumber(),
                      })
                    })
                  })


                })

                this.allBooks.push({
                  "address": userAddress,
                  "books": userBooks,
                })

              })

              console.log("afterall : userBooks", this.allBooks)


            })


          })
          .catch(e => {
            console.error(e.message);
            this.message = "Transaction failed"
          });
      },

    }


  }
</script>

<style scoped>

</style>
