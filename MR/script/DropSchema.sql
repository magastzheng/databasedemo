/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases v6.3.2                     */
/* Target DBMS:           MS SQL Server 2005                              */
/* Project file:          MR.dez                                          */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database drop script                            */
/* Created on:            2013-10-23 17:57                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE [dbo].[FailedConversionInvestment] DROP CONSTRAINT [FailedConversion_FailedConversionInvestment]
GO


/* ---------------------------------------------------------------------- */
/* Drop table "FailedConversionInvestment"                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

/* Drop table */

DROP TABLE [dbo].[FailedConversionInvestment]
GO


/* ---------------------------------------------------------------------- */
/* Drop table "FailedConversion"                                          */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE [dbo].[FailedConversion] DROP CONSTRAINT [DEF_FailedConversion_TimeCreated]
GO


ALTER TABLE [dbo].[FailedConversion] DROP CONSTRAINT [PK_FailedConversion]
GO


/* Drop table */

DROP TABLE [dbo].[FailedConversion]
GO

