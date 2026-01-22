import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(
  defineConfig({
    title: 'Rhizome',
    description: 'Tools for programmable creativity',

    themeConfig: {
      nav: [
        { text: 'Home', link: '/' },
        { text: 'About', link: '/about' },
        { text: 'Projects', link: '/projects/' },
        {
          text: 'Docs',
          items: [
            { text: 'Code Intelligence', items: [
              { text: 'Moss', link: 'https://rhizome-lab.github.io/moss/' },
            ]},
            { text: 'Generation', items: [
              { text: 'Resin', link: 'https://rhizome-lab.github.io/resin/' },
              { text: 'Dew', link: 'https://rhizome-lab.github.io/dew/' },
            ]},
            { text: 'Games & Worlds', items: [
              { text: 'Frond', link: 'https://rhizome-lab.github.io/frond/' },
              { text: 'Hypha', link: 'https://rhizome-lab.github.io/hypha/' },
            ]},
            { text: 'Data Transformation', items: [
              { text: 'Cambium', link: 'https://rhizome-lab.github.io/cambium/' },
              { text: 'Liana', link: 'https://rhizome-lab.github.io/liana/' },
              { text: 'Siphon', link: 'https://rhizome-lab.github.io/siphon/' },
            ]},
            { text: 'Runtime & Interface', items: [
              { text: 'Spore', link: 'https://rhizome-lab.github.io/spore/' },
              { text: 'Canopy', link: 'https://rhizome-lab.github.io/canopy/' },
            ]},
            { text: 'Infrastructure', items: [
              { text: 'Nursery', link: 'https://rhizome-lab.github.io/nursery/' },
              { text: 'Pith', link: 'https://rhizome-lab.github.io/pith/' },
              { text: 'Flora', link: 'https://rhizome-lab.github.io/flora/' },
              { text: 'Trellis', link: 'https://rhizome-lab.github.io/trellis/' },
            ]},
          ]
        },
      ],

      sidebar: {
        '/': [
          {
            text: 'Overview',
            items: [
              { text: 'About', link: '/about' },
              { text: 'Vision', link: '/vision' },
              { text: 'Problems', link: '/problems' },
              { text: 'Collaboration', link: '/collaboration' },
              { text: 'Use Cases', link: '/use-cases' },
              { text: 'Architecture', link: '/architecture' },
              { text: 'Integration', link: '/integration' },
            ]
          },
          {
            text: 'Code Intelligence',
            collapsed: true,
            items: [
              { text: 'Moss', link: '/projects/moss' },
            ]
          },
          {
            text: 'Generation',
            collapsed: true,
            items: [
              { text: 'Resin', link: '/projects/resin' },
              { text: 'Dew', link: '/projects/dew' },
            ]
          },
          {
            text: 'Games & Worlds',
            collapsed: true,
            items: [
              { text: 'Frond', link: '/projects/frond' },
              { text: 'Hypha', link: '/projects/hypha' },
            ]
          },
          {
            text: 'Data Transformation',
            collapsed: true,
            items: [
              { text: 'Cambium', link: '/projects/cambium' },
              { text: 'Liana', link: '/projects/liana' },
              { text: 'Siphon', link: '/projects/siphon' },
            ]
          },
          {
            text: 'Runtime & Interface',
            collapsed: true,
            items: [
              { text: 'Spore', link: '/projects/spore' },
              { text: 'Canopy', link: '/projects/canopy' },
            ]
          },
          {
            text: 'Infrastructure',
            collapsed: true,
            items: [
              { text: 'Nursery', link: '/projects/nursery' },
              { text: 'Pith', link: '/projects/pith' },
              { text: 'Flora', link: '/projects/flora' },
              { text: 'Trellis', link: '/projects/trellis' },
            ]
          },
          {
            text: 'Community',
            items: [
              { text: 'Contributing', link: '/contributing' },
            ]
          },
        ]
      },

      socialLinks: [
        { icon: 'github', link: 'https://github.com/rhizome-lab' }
      ],

      search: {
        provider: 'local'
      },
    },

    vite: {
      optimizeDeps: {
        include: ['mermaid'],
      },
    },
  }),
)
