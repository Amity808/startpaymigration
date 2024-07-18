"use client";

import React, { useEffect, useState } from "react";
import SendGiftMail from "./email/SendGiftMail";
import CustomInput from "./ui/CustomInput";
import { render } from "@react-email/components";
import { peanut } from "@squirrel-labs/peanut-sdk";
import { ethers } from "ethers";
import toast from "react-hot-toast";
import { useAccount, useReadContract, useSimulateContract, useWriteContract } from "wagmi";
import useLoading from "~~/hooks/useLoading";
import { useScaffoldWriteContract } from "../hooks/scaffold-eth";


const GiftForm = () => {
  const { isLoading: isLoadGift, startLoading: startLoadPGift, stopLoading: stopLoadPGift } = useLoading();
  const [amount, setAmount] = useState("");
  const [linkStatus, setLinkStatus] = useState("");
  const { address } = useAccount();
  const [link, setLink] = useState("");
  const [txStatus, setTxStatus] = useState("");
  const [content, setContent] = useState("");
  const [email, setEmail] = useState("");
  const [recipentName, setRecipentName] = useState("");
  const [subjectLine, setSubjectLine] = useState("");


  const { writeContractAsync, isPending } = useScaffoldWriteContract("StartPay")
  const createPyament = async () => {
    if (!window.ethereum) {
        throw new Error("MetaMask is not installed");
      }
  
      // Request account access if needed
      await window.ethereum.request({ method: 'eth_requestAccounts' });
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
      const signer = await provider.getSigner();
      if (!signer) throw new Error("Connect your wallet");
      const network = await signer.provider.getNetwork();
      const chainId = network.chainId;
      console.log(chainId);
      const { link, txHash } = await peanut.createLink({
        structSigner: signer,
        linkDetails: {
            chainId, 
            tokenAmount: '0.001',
            tokenDecimals: 18,
            tokenType: 0
        }
      });
      setLink(link);
      console.log(link)
      return link;
    } catch (error) {
        console.log(error);
    }
  };

  const sendEmail = async (link) => {
    const emailHTML = render(<SendGiftMail userFirstname={recipentName} address={address} link={link} content={content} />)

    try {
        const response = await fetch('/api/send/', {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                email: 'codestorm808@gmail.com',
                reciever: email,
                subject: subjectLine,
                message: emailHTML,
            })
        });
        const data = await response.json()
        console.log(data)
    } catch (error) {
        console.log(error)
    }
  }

  const handlewrite = async () => {
    try {
        await writeContractAsync({
            functionName: "giftUser",
            args: [address, link, content],
        })
    } catch (error) {
        console.error(error, "error writing")
    }
  }
  console.log(isLoadGift, "loading");

  const perfromGift = async (e) => {
    e.preventDefault();
    startLoadPGift();
    try {
        const link = await createPyament();
        console.log(link)
        if(link) {
            await sendEmail(link);
            await handlewrite()
        }
        stopLoadPGift()
    } catch (error) {
        stopLoadPGift()
    }
  }

  return (
    <div>
      <form onSubmit={perfromGift} className="  flex gap-3 flex-col justify-center items-center mt-6">
        <p className=" text-xl font-semibold">Start payment</p>
        <CustomInput
          className={"w-[500px] "}
          onChange={e => setRecipentName(e.target.value)}
          placeholder={"Recipent Name"}
        />
        <CustomInput
          className={" w-[500px]"}
          onChange={e => setEmail(e.target.value)}
          placeholder={"Reciepent Email"}
        />
        <CustomInput
          className={" w-[500px]"}
          onChange={e => setSubjectLine(e.target.value)}
          placeholder={"Email Subject Line"}
        />
        <CustomInput className={" w-[500px]"} onChange={e => setAmount(e.target.value)} placeholder={"amount"} />
        <CustomInput
          className={" w-[500px]"}
          onChange={e => setContent(e.target.value)}
          placeholder={"Email content"}
        />
        <button className=" rounded-md bg-purple-800 py-3 px-2" >
          Send payment
        </button>
      </form>
      <button onClick={createPyament}>pay</button>
    </div>
  );
};

export default GiftForm;
