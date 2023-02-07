import { ethers } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

export const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const NETWORK_NAME: { [chainId: number]: string } = {
	80001: "mumbai",
	137: "polygon",
	1337: "development",
};

export const networkName = (chainId: number) =>
	NETWORK_NAME[chainId] ? NETWORK_NAME[chainId] : new Error("Cannot find chain name");

export const verify = async (
	hardhat: HardhatRuntimeEnvironment,
	adddress: string,
	chainId: number,
	params?: unknown[]
) => {
	if ([80001, 137, 1337].includes(chainId)) {
		await sleep(60 * 1000);
		try {
			hardhat.run("verify:verify", {
				address: adddress,
				network: networkName(chainId),
				constructorArgsParams: params ?? [],
			});
		} catch (e) {
			console.log(e);
		}
	} else {
		console.log(`Cannot verify for ChainId ${chainId}`);
	}
};

export function keccak256(text: string) {
	return ethers.utils.keccak256(ethers.utils.toUtf8Bytes(text));
}
