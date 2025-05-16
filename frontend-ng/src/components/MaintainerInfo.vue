<script lang="ts">
import { defineComponent, h } from "vue";

export default defineComponent({
  props: {
    maintainer: {
      type: Object,
      required: true,
    },
  },
  setup(props) {
    let elements = [];
    if (props.maintainer.github) {
      let profile = `https://github.com/${props.maintainer.github}`;
      elements.push(h("a", { href: profile }, props.maintainer.name));
    } else {
      elements.push(h("span", {}, props.maintainer.name));
    }
    if (props.maintainer.email) {
      elements.push(" ");
      let mailto = h("a", {href: `mailto:${props.maintainer.email}`}, props.maintainer.email)
      elements.push(h("span", {}, ["<", mailto, ">"]));
    }
    return () => elements;
  }
})
</script>

<style scoped>
</style>
