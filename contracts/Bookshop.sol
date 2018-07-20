pragma solidity ^0.4.18;

contract Bookshop {
    mapping(address => uint) public account; // Alice-> money

    mapping(address => string) public publicKeys; // Alice-> public-key

    struct  Book {  // A book
        string name;
        string bookHash;
        uint price;
        string aesKey;
        string aesIv;
    }

    Book[] public books; // All books

    mapping(address => uint[]) public bookRegister;  // Alice -> her book index  todo , need an array

    address[] public users;      // system's user
    mapping(address => bool) userHaveAdd;

    struct  Order {
        address buyer;
        address seller;
        uint price;
        uint bookIndex;
        bool closed;
        string goodsHash;
        string aesKey;
        string aesIv;
        string buyerPublicKey;
    }

    Order[] orders; // All orders


    mapping(address => uint[]) userSellOrders; // Alice -> orderIds
    mapping(address => uint[]) userBuyOrders; // Alice -> orderIds


    function getFakeFund() public returns (bool success) {
        account[msg.sender] += 100;
        return true;
    }

    function getBalance() public view returns (uint) {
      return account[msg.sender];
    }

    // Purpose: Publish a book hash to system
    // Logic: In browser, first if user have registerd, if not ,call this function to register with a public key
    function setPublickey(string publicKey) public returns (bool success) {
      publicKeys[msg.sender] = publicKey;

      if (userHaveAdd[msg.sender] == false) {
        users.push(msg.sender);
        userHaveAdd[msg.sender] = true;
      }

      return true;
    }

    function getPublickey() public view returns (string) {
      return publicKeys[msg.sender];
    }



    // Purpose: User publish a book to system
    // Total Logic:
    // 1. Alice chook a pdf to upload,
    // 2. Alice put in private key
    // 3. Browser ask system for Alice's pubkey,
    // 4. Browser encrypt uploaded pdf
    // 5. Browser upload encrypted pdf to IPFS to get a hash
    // 6. Browser call this function, with name, price [Alice provide] and bookHash [from ipfs]
    function publishBook(string name, string bookHash, uint price, string aesKey, string aesIv) public returns (uint bookId) {
        uint len = books.push(Book(name, bookHash, price, aesKey, aesIv));
        bookId = len -1;
        bookRegister[msg.sender].push(bookId);
        // return true;
    }

    // get msg.senders published books
//    function getBooks() public view returns (uint[]) {
//      return bookRegister[msg.sender];
//    }

    function getBook(uint bookId) public view returns (uint, string, uint, string, string, string) {
      return (bookId, books[bookId].name, books[bookId].price, books[bookId].aesKey, books[bookId].aesIv, books[bookId].bookHash);
    }

    function getUsers() public view returns (address[]) {
      return users;
    }

    function getUserBooks(address userAddress) public view returns (uint[]) {
      return bookRegister[userAddress];
    }

    // Purpose: Bob make a book buy order to Alice
    // Logic:
    // 1. Browser call this function with params
    function makeOrder(address buyer, address seller, uint price, uint bookIndex) public returns (uint orderId) {
      orderId = orders.push(Order(buyer, seller, price, bookIndex, false, "", "", "", publicKeys[buyer])) - 1;

      userSellOrders[seller].push(orderId);
      userBuyOrders[buyer].push(orderId);



      // TODO: If something i don't want set, how to do?
        // return true;
    }


    function getUserSellOrders() public view returns (uint[]) {
        return userSellOrders[msg.sender];
    }

    function getUserBuyOrders() public view returns (uint[]) {
      return userBuyOrders[msg.sender];
    }

    function getOrder(uint orderId) public view returns (uint, address, address, uint, uint, bool, string) {
      return (
      orderId,
      orders[orderId].buyer,
      orders[orderId].seller,
      orders[orderId].price,
      orders[orderId].bookIndex,
      orders[orderId].closed,
      orders[orderId].goodsHash
      );
    }
  // a workround of 'CompilerError: Stack too deep, try removing local variables.'
  function getOrder2(uint orderId) public view returns (string, string, string) {
    return (orders[orderId].aesKey, orders[orderId].aesIv, orders[orderId].buyerPublicKey);
  }



    // purpose: Alice argree with the order
    // Total Logic:
    // Alice press 'agree' button ,provide her privite key.
    // 1. Browser get oreder bookIndex, bob's publickey
    // 2. Ask for system the bookhash
    // 3. decrypt with private key.
    // 4. Encrypt with bob's pubkey -> goodsHash
    // 5. Call this function, with orderId, goodsHash
    // 6. send to IPFS
    function approveOrder(uint orderId, string goodsHash, string aesKey, string aesIv) public returns (bool success) {
        // TODO Need lock account balance first, with other strategy, prevent double pay

        account[orders[orderId].buyer] -= orders[orderId].price;
        account[orders[orderId].seller] += orders[orderId].price;

        orders[orderId].goodsHash = goodsHash;
        orders[orderId].closed = true;
        orders[orderId].aesKey = aesKey;
        orders[orderId].aesIv = aesIv;

        return true;
    }

    // purpose: Alice decline the order
    // Total Logic:
    // Alice press 'decline' button
    // 1. Browser get oreder bookIndex, bob's publickey
    // 2. Ask for system the bookhash
    // 3. decrypt with private key.
    // 4. Encrypt with bob's pubkey -> goodsHash
    // 5. Call this function, with orderId, goodsHash
    // 6. send to IPFS
    function declineOrder(uint orderId) public returns (bool success) {
        orders[orderId].closed = true;
        // o.closed = true;
        return true;
    }


    // direct get
    // function getAllbooks(address user)
    // function getAccount(address user)
    // function getBookHash(address user)


}

