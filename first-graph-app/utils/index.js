import axios from "axios";

export async function subgraphQuery(query) {
  try {
    const SUBRAPH_URL =
      "https://api.thegraph.com/subgraphs/name/mitsue-eth/learnweb3";
    const response = await axios.post(SUBRAPH_URL, {
      query,
    });
    if (response.data.error) {
      console.error(response.data.errors);
      throw new Error(`Error making subgraph query ${response.data.errors}`);
    }
    return response.data.data;
  } catch (error) {
    console.error(error);
    throw new Error(`Could not query the subgraph due to ${error.message}`);
  }
}
