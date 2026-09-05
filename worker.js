export default {
  fetch() {
    return Response.redirect(
      "https://raw.githubusercontent.com/taiansu/tsunpi/main/setup.sh",
      302,
    );
  },
};
