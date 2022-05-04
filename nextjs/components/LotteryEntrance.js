import { useMoralis, useWeb3ExecuteFunction, useWeb3Contract } from "react-moralis";
import { useState, useEffect } from "react";
import {abi} from "../constants/abi.json"
export default function LotteryEntrance(){

    const {isWeb3Enabled} = useMoralis();
    const [recentWinner, setRecentWinner] = useState("0")

    const {runContractFunction: enterRaffle} = useWeb3Contract({
        abi: abi,
        contractAddress: "0x91787f06b2b748a154f13135FE1BeA2A22e01F7B",
        functionName: "enterRaffle",
        msgValue: "100000000000000000", //0.1ETH
    })
    //View Functions
    const { data, error, fetch, isFetching, isLoading } =  useWeb3Contract({
        abi: abi,
        contractAddress: "0x91787f06b2b748a154f13135FE1BeA2A22e01F7B",
        functionName: "s_recentWinner",
    })
    
    async function updateUi(){
        // const recentWinnerFromCall = await getRecentWinner();
        if(typeof data === 'undefined')
            {
                setRecentWinner(0);
                console.log("Hello World");
            }
        else 
            {setRecentWinner(1);
            console.log("Hello World");
            }
    }

    useEffect(()=> {
        if(isWeb3Enabled){
            updateUi()
        }
    }, [isWeb3Enabled])

    return (
        <div>
            <button className="rounded ml-auto font-bold bg-blue-500" onClick={async () => {
                await enterRaffle()
            }}>
                Enter Lottery!!
            </button>
            <div>
                The Recent Winner was: {recentWinner}
            </div>
        </div>
    )
}