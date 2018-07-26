import Vue from 'vue'
import Router from 'vue-router'
import Layout from '@/components/Layout'
import Account from '@/components/Account'
import Books from '@/components/Books'
import Orders from '@/components/Orders'
import Download from '@/components/Download'

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Layout',
      component: Layout,
      redirect: "/Account",
      children: [
        {
          path: '/account',
          name: 'Account',
          component: Account,
        },
        {
          path: '/books',
          name: 'Books',
          component: Books,
        },
        {
          path: '/orders',
          name: 'Orders',
          component: Orders,
        },
        {
          path: '/download',
          name: 'Download',
          component: Download,
        },
      ]
    },
  ]
})
